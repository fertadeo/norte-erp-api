import { Request, Response } from 'express';
import { executeQuery } from '../config/database';
import { ApiResponse, Client, ClientType } from '../types';
import { validationResult } from 'express-validator';

export class ClientController {
  
  // Generate auto-incremental code based on client type
  private async generateClientCode(clientType: ClientType): Promise<string> {
    try {
      const prefix = clientType.toUpperCase().substring(0, 3); // MAY, MIN, PER
      
      // Get the highest code number for this client type
      const query = `
        SELECT code 
        FROM clients 
        WHERE client_type = ? AND code LIKE ?
        ORDER BY code DESC 
        LIMIT 1
      `;
      
      const [result] = await executeQuery(query, [clientType, `${prefix}%`]);
      
      let nextNumber = 1;
      
      if (result && result.code) {
        // Extract the number from the existing code (e.g., "MAY001" -> 1)
        const match = result.code.match(new RegExp(`${prefix}(\\d+)`));
        if (match && match[1]) {
          nextNumber = parseInt(match[1], 10) + 1;
        }
      }
      
      // Format the code with leading zeros (e.g., MAY001, MIN002, PER003)
      const code = `${prefix}${nextNumber.toString().padStart(3, '0')}`;
      
      console.log(`Generated code for ${clientType}: ${code}`);
      return code;
    } catch (error) {
      console.error('Error generating client code:', error);
      throw new Error('Failed to generate client code');
    }
  }
  // GET /api/clients - Get all clients with pagination and filters
  public async getAllClients(req: Request, res: Response): Promise<void> {
    try {
      console.log('=== getAllClients START ===');
      
      // Extract query parameters
      const { 
        page, 
        limit, 
        search, 
        status, 
        city, 
        all = 'false' // New parameter to get all clients
      } = req.query;
      
      console.log('Query params:', { page, limit, search, status, city, all });
      
      // Build WHERE conditions
      const whereConditions: string[] = [];
      const queryParams: any[] = [];
      
      // Search filter
      if (search) {
        whereConditions.push('(name LIKE ? OR code LIKE ? OR email LIKE ?)');
        const searchTerm = `%${search}%`;
        queryParams.push(searchTerm, searchTerm, searchTerm);
      }
      
      // Status filter
      if (status === 'active') {
        whereConditions.push('is_active = 1');
      } else if (status === 'inactive') {
        whereConditions.push('is_active = 0');
      }
      
      // City filter
      if (city) {
        whereConditions.push('city = ?');
        queryParams.push(city);
      }
      
      const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';
      
      // Get total count
      const countQuery = `SELECT COUNT(*) as total FROM clients ${whereClause}`;
      console.log('Count query:', countQuery, queryParams);
      
      const [countResult] = await executeQuery(countQuery, queryParams);
      const total = countResult?.total || 0;
      console.log('Total clients found:', total);
      
      // Build main query
      let selectQuery = `
        SELECT 
          id,
          code,
          client_type,
          name,
          email,
          phone,
          address,
          city,
          country,
          is_active,
          created_at,
          updated_at
        FROM clients 
        ${whereClause}
        ORDER BY created_at DESC
      `;
      
      // Add pagination if not requesting all clients
      if (all === 'true') {
        console.log('Getting ALL clients (no pagination)');
      } else {
        const pageNum = parseInt(String(page), 10) || 1;
        const limitNum = parseInt(String(limit), 10) || 10;
        const offset = (pageNum - 1) * limitNum;
        
        selectQuery += ` LIMIT ${limitNum} OFFSET ${offset}`;
        console.log(`Pagination: page ${pageNum}, limit ${limitNum}, offset ${offset}`);
      }
      
      console.log('Select query:', selectQuery, queryParams);
      
      const clients = await executeQuery(selectQuery, queryParams);
      console.log('Clients retrieved:', clients?.length || 0);
      
      // Build response
      const response: ApiResponse<any> = {
        success: true,
        message: all === 'true' ? 'All clients retrieved successfully' : 'Clients retrieved successfully',
        data: {
          clients,
          ...(all !== 'true' && {
            pagination: {
              page: parseInt(String(page), 10) || 1,
              limit: parseInt(String(limit), 10) || 10,
              total,
              totalPages: Math.ceil(total / (parseInt(String(limit), 10) || 10))
            }
          }),
          ...(all === 'true' && {
            total: total,
            message: 'All clients retrieved (no pagination applied)'
          })
        },
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Get clients error:', error);
      console.error('Error stack:', error instanceof Error ? error.stack : 'No stack');
      const response: ApiResponse = {
        success: false,
        message: 'Error retrieving clients',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // GET /api/clients/:id - Get client by ID
  public async getClientById(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      
      const query = `
        SELECT 
          id,
          code,
          client_type,
          name,
          email,
          phone,
          address,
          city,
          country,
          is_active,
          created_at,
          updated_at
        FROM clients 
        WHERE id = ?
      `;
      
      const [client] = await executeQuery(query, [id]);
      
      if (!client) {
        const response: ApiResponse = {
          success: false,
          message: 'Client not found',
          timestamp: new Date().toISOString()
        };
        res.status(404).json(response);
        return;
      }
      
      const response: ApiResponse<Client> = {
        success: true,
        message: 'Client retrieved successfully',
        data: client,
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Get client by ID error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error retrieving client',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // POST /api/clients - Create new client
  public async createClient(req: Request, res: Response): Promise<void> {
    try {
      // Check validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        const response: ApiResponse = {
          success: false,
          message: 'Validation failed',
          error: errors.array().map(err => err.msg).join(', '),
          timestamp: new Date().toISOString()
        };
        res.status(400).json(response);
        return;
      }

      const { 
        name, 
        client_type = ClientType.MINORISTA, 
        email, 
        phone, 
        address, 
        city, 
        country = 'Argentina' 
      } = req.body;
      
      console.log('Creating client with type:', client_type);
      
      // Generate automatic code based on client type
      const code = await this.generateClientCode(client_type);
      
      const insertQuery = `
        INSERT INTO clients (code, client_type, name, email, phone, address, city, country, is_active)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)
      `;
      
      const result = await executeQuery(insertQuery, [code, client_type, name, email, phone, address, city, country]);
      
      // Get the created client
      const [newClient] = await executeQuery(
        'SELECT * FROM clients WHERE id = ?', 
        [result.insertId]
      );
      
      const response: ApiResponse<Client> = {
        success: true,
        message: 'Client created successfully',
        data: newClient,
        timestamp: new Date().toISOString()
      };
      
      res.status(201).json(response);
    } catch (error) {
      console.error('Create client error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error creating client',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // PUT /api/clients/:id - Update client
  public async updateClient(req: Request, res: Response): Promise<void> {
    try {
      console.log('Update client request body:', req.body);
      console.log('Update client params:', req.params);
      
      // Check validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('Validation errors:', errors.array());
        const response: ApiResponse = {
          success: false,
          message: 'Validation failed',
          error: errors.array().map(err => err.msg).join(', '),
          timestamp: new Date().toISOString()
        };
        res.status(400).json(response);
        return;
      }

      const { id } = req.params;
      const { code, client_type, name, email, phone, address, city, country, is_active } = req.body;
      
      console.log('Extracted fields:', { code, name, email, phone, address, city, country, is_active });
      
      // Check if client exists
      const [existingClient] = await executeQuery('SELECT id FROM clients WHERE id = ?', [id]);
      if (!existingClient) {
        const response: ApiResponse = {
          success: false,
          message: 'Client not found',
          timestamp: new Date().toISOString()
        };
        res.status(404).json(response);
        return;
      }
      
      // Check if code is being changed and if new code already exists
      if (code) {
        const [codeExists] = await executeQuery(
          'SELECT id FROM clients WHERE code = ? AND id != ?', 
          [code, id]
        );
        if (codeExists) {
          const response: ApiResponse = {
            success: false,
            message: 'Client code already exists',
            timestamp: new Date().toISOString()
          };
          res.status(409).json(response);
          return;
        }
      }
      
      // Build dynamic update query based on provided fields
      const updateFields: string[] = [];
      const updateValues: any[] = [];
      
      if (code !== undefined) {
        updateFields.push('code = ?');
        updateValues.push(code);
      }
      if (client_type !== undefined) {
        updateFields.push('client_type = ?');
        updateValues.push(client_type);
      }
      if (name !== undefined) {
        updateFields.push('name = ?');
        updateValues.push(name);
      }
      if (email !== undefined) {
        updateFields.push('email = ?');
        updateValues.push(email);
      }
      if (phone !== undefined) {
        updateFields.push('phone = ?');
        updateValues.push(phone);
      }
      if (address !== undefined) {
        updateFields.push('address = ?');
        updateValues.push(address);
      }
      if (city !== undefined) {
        updateFields.push('city = ?');
        updateValues.push(city);
      }
      if (country !== undefined) {
        updateFields.push('country = ?');
        updateValues.push(country);
      }
      if (is_active !== undefined) {
        updateFields.push('is_active = ?');
        updateValues.push(is_active);
      }
      
      // Add updated_at timestamp
      updateFields.push('updated_at = CURRENT_TIMESTAMP');
      
      // Check if there are fields to update
      if (updateFields.length === 1) { // Only updated_at
        const response: ApiResponse = {
          success: false,
          message: 'No fields to update',
          timestamp: new Date().toISOString()
        };
        res.status(400).json(response);
        return;
      }
      
      const updateQuery = `UPDATE clients SET ${updateFields.join(', ')} WHERE id = ?`;
      updateValues.push(id);
      
      await executeQuery(updateQuery, updateValues);
      
      // Get the updated client
      const [updatedClient] = await executeQuery('SELECT * FROM clients WHERE id = ?', [id]);
      
      const response: ApiResponse<Client> = {
        success: true,
        message: 'Client updated successfully',
        data: updatedClient,
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Update client error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error updating client',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // DELETE /api/clients/:id - Delete client (soft delete)
  public async deleteClient(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      
      // Check if client exists
      const [existingClient] = await executeQuery('SELECT id FROM clients WHERE id = ?', [id]);
      if (!existingClient) {
        const response: ApiResponse = {
          success: false,
          message: 'Client not found',
          timestamp: new Date().toISOString()
        };
        res.status(404).json(response);
        return;
      }
      
      // Check if client has associated orders
      const [hasOrders] = await executeQuery(
        'SELECT COUNT(*) as count FROM orders WHERE client_id = ?', 
        [id]
      );
      
      if (hasOrders?.count > 0) {
        // Soft delete - deactivate client
        await executeQuery('UPDATE clients SET is_active = 0 WHERE id = ?', [id]);
        const response: ApiResponse = {
          success: true,
          message: 'Client deactivated successfully (has associated orders)',
          timestamp: new Date().toISOString()
        };
        res.status(200).json(response);
      } else {
        // Hard delete - remove client completely
        await executeQuery('DELETE FROM clients WHERE id = ?', [id]);
        const response: ApiResponse = {
          success: true,
          message: 'Client deleted successfully',
          timestamp: new Date().toISOString()
        };
        res.status(200).json(response);
      }
    } catch (error) {
      console.error('Delete client error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error deleting client',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }

  // GET /api/clients/stats - Get client statistics
  public async getClientStats(req: Request, res: Response): Promise<void> {
    try {
      const statsQuery = `
        SELECT 
          COUNT(*) as total_clients,
          SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active_clients,
          SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive_clients,
          COUNT(DISTINCT city) as cities_count,
          SUM(CASE WHEN created_at >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) THEN 1 ELSE 0 END) as new_clients_this_month
        FROM clients
      `;
      
      const [stats] = await executeQuery(statsQuery);
      
      const response: ApiResponse = {
        success: true,
        message: 'Client statistics retrieved successfully',
        data: stats,
        timestamp: new Date().toISOString()
      };
      
      res.status(200).json(response);
    } catch (error) {
      console.error('Get client stats error:', error);
      const response: ApiResponse = {
        success: false,
        message: 'Error retrieving client statistics',
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
      res.status(500).json(response);
    }
  }
}
