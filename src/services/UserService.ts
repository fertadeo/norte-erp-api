import bcrypt from 'bcryptjs';
import { UserRepository, DBUser } from '../repositories/UserRepository';

export type CreateUserInput = {
  username: string;
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role: DBUser['role'];
  isActive?: boolean;
};

const ALLOWED_ROLES: DBUser['role'][] = [
  'admin', 'manager', 'employee', 'viewer',
  'gerencia', 'ventas', 'logistica', 'finanzas'
];

export const UserService = {
  isRoleAllowed(role: string): role is DBUser['role'] {
    return ALLOWED_ROLES.includes(role as DBUser['role']);
  },

  async createUser(input: CreateUserInput): Promise<number> {
    if (!this.isRoleAllowed(input.role)) {
      throw new Error('Invalid role');
    }
    const password_hash = await bcrypt.hash(input.password, 10);
    const id = await UserRepository.create({
      username: input.username,
      email: input.email,
      password_hash,
      first_name: input.firstName,
      last_name: input.lastName,
      role: input.role,
      is_active: input.isActive ?? true
    });
    return id;
  }
};
