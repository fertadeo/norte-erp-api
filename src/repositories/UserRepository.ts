import { executeQuery } from "../config/database";
import { RowDataPacket } from "mysql2";

export interface DBUser extends RowDataPacket {
  id: number;
  username: string;
  email: string;
  password_hash: string;
  first_name: string;
  last_name: string;
  role: 'admin' | 'manager' | 'employee' | 'viewer' | 'gerencia' | 'ventas' | 'logistica' | 'finanzas';
  is_active: number | boolean;
  created_at: string;
  updated_at: string;
}

export const UserRepository = {
  async findByUsername(username: string): Promise<DBUser | null> {
    const sql = `SELECT * FROM users WHERE username = ? LIMIT 1`;
    const rows = await executeQuery(sql, [username]);
    const arr = rows as DBUser[];
    return arr && arr.length ? arr[0] : null;
  },

  async findById(id: number): Promise<DBUser | null> {
    const sql = `SELECT * FROM users WHERE id = ? LIMIT 1`;
    const rows = await executeQuery(sql, [id]);
    const arr = rows as DBUser[];
    return arr && arr.length ? arr[0] : null;
  },

  async countAll(): Promise<number> {
    const sql = `SELECT COUNT(*) as cnt FROM users`;
    const rows = await executeQuery(sql);
    const arr = rows as Array<{ cnt: number }>;
    return arr && arr.length ? arr[0].cnt : 0;
  },

  async create(user: { username: string; email: string; password_hash: string; first_name: string; last_name: string; role: DBUser['role']; is_active?: boolean }): Promise<number> {
    const sql = `INSERT INTO users (username, email, password_hash, first_name, last_name, role, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)`;
    const result: any = await executeQuery(sql, [user.username, user.email, user.password_hash, user.first_name, user.last_name, user.role, user.is_active ?? true]);
    return result.insertId as number;
  }
};
