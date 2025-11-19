// Database types for MyHome
// Generated from Supabase schema for Story 1-2
// These types can be regenerated with: npx supabase gen types typescript

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type MemberRole = 'admin' | 'member';

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          display_name: string | null;
          avatar_url: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          display_name?: string | null;
          avatar_url?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          display_name?: string | null;
          avatar_url?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'profiles_id_fkey';
            columns: ['id'];
            referencedRelation: 'users';
            referencedColumns: ['id'];
          }
        ];
      };
      homes: {
        Row: {
          id: string;
          name: string;
          invite_code: string;
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          invite_code?: string;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          invite_code?: string;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'homes_created_by_fkey';
            columns: ['created_by'];
            referencedRelation: 'users';
            referencedColumns: ['id'];
          }
        ];
      };
      home_members: {
        Row: {
          id: string;
          user_id: string;
          home_id: string;
          role: MemberRole;
          joined_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          home_id: string;
          role?: MemberRole;
          joined_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          home_id?: string;
          role?: MemberRole;
          joined_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'home_members_user_id_fkey';
            columns: ['user_id'];
            referencedRelation: 'users';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'home_members_home_id_fkey';
            columns: ['home_id'];
            referencedRelation: 'homes';
            referencedColumns: ['id'];
          }
        ];
      };
      shopping_list_items: {
        Row: {
          id: string;
          home_id: string;
          name: string;
          quantity: string | null;
          category: string | null;
          is_purchased: boolean;
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          home_id: string;
          name: string;
          quantity?: string | null;
          category?: string | null;
          is_purchased?: boolean;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          home_id?: string;
          name?: string;
          quantity?: string | null;
          category?: string | null;
          is_purchased?: boolean;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'shopping_list_items_home_id_fkey';
            columns: ['home_id'];
            referencedRelation: 'homes';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'shopping_list_items_created_by_fkey';
            columns: ['created_by'];
            referencedRelation: 'users';
            referencedColumns: ['id'];
          }
        ];
      };
      push_subscriptions: {
        Row: {
          id: string;
          user_id: string;
          token: string;
          platform: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          token: string;
          platform?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          token?: string;
          platform?: string | null;
          created_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'push_subscriptions_user_id_fkey';
            columns: ['user_id'];
            referencedRelation: 'users';
            referencedColumns: ['id'];
          }
        ];
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      generate_invite_code: {
        Args: Record<PropertyKey, never>;
        Returns: string;
      };
      get_user_home_id: {
        Args: Record<PropertyKey, never>;
        Returns: string;
      };
    };
    Enums: {
      member_role: MemberRole;
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
}

// Convenience types for common operations
export type Profile = Database['public']['Tables']['profiles']['Row'];
export type ProfileInsert = Database['public']['Tables']['profiles']['Insert'];
export type ProfileUpdate = Database['public']['Tables']['profiles']['Update'];

export type Home = Database['public']['Tables']['homes']['Row'];
export type HomeInsert = Database['public']['Tables']['homes']['Insert'];
export type HomeUpdate = Database['public']['Tables']['homes']['Update'];

export type HomeMember = Database['public']['Tables']['home_members']['Row'];
export type HomeMemberInsert = Database['public']['Tables']['home_members']['Insert'];
export type HomeMemberUpdate = Database['public']['Tables']['home_members']['Update'];

export type ShoppingListItem = Database['public']['Tables']['shopping_list_items']['Row'];
export type ShoppingListItemInsert = Database['public']['Tables']['shopping_list_items']['Insert'];
export type ShoppingListItemUpdate = Database['public']['Tables']['shopping_list_items']['Update'];

export type PushSubscription = Database['public']['Tables']['push_subscriptions']['Row'];
export type PushSubscriptionInsert = Database['public']['Tables']['push_subscriptions']['Insert'];
export type PushSubscriptionUpdate = Database['public']['Tables']['push_subscriptions']['Update'];
