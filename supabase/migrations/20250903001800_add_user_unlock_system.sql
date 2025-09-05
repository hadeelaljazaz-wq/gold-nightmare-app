-- Location: supabase/migrations/20250903001800_add_user_unlock_system.sql
-- Schema Analysis: Adding is_unlocked field to existing user_profiles table
-- Integration Type: Modification to existing auth system
-- Dependencies: user_profiles table (existing)

-- Add is_unlocked column to existing user_profiles table
ALTER TABLE public.user_profiles 
ADD COLUMN is_unlocked BOOLEAN DEFAULT false;

-- Add index for performance
CREATE INDEX idx_user_profiles_is_unlocked ON public.user_profiles(is_unlocked);

-- Create function to check user unlock status
CREATE OR REPLACE FUNCTION public.is_user_unlocked(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COALESCE(
    (SELECT is_unlocked FROM public.user_profiles WHERE id = user_uuid LIMIT 1),
    false
)
$$;

-- Create function for admins to manage user unlock status
CREATE OR REPLACE FUNCTION public.admin_toggle_user_unlock(target_user_id UUID, unlock_status BOOLEAN)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    admin_role TEXT;
BEGIN
    -- Check if current user is admin
    SELECT role INTO admin_role
    FROM public.user_profiles
    WHERE id = auth.uid()
    LIMIT 1;

    IF admin_role != 'admin' THEN
        RETURN QUERY SELECT false, 'Unauthorized: Admin access required';
        RETURN;
    END IF;

    -- Update user unlock status
    UPDATE public.user_profiles
    SET is_unlocked = unlock_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = target_user_id;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'User unlock status updated successfully';
    ELSE
        RETURN QUERY SELECT false, 'User not found';
    END IF;
END;
$$;

-- Create function to get all users for admin dashboard
CREATE OR REPLACE FUNCTION public.admin_get_all_users()
RETURNS TABLE(
    id UUID,
    email TEXT,
    full_name TEXT,
    role TEXT,
    is_unlocked BOOLEAN,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ
)
LANGUAGE sql
SECURITY DEFINER
AS $$
SELECT 
    up.id,
    up.email,
    up.full_name,
    up.role::TEXT,
    up.is_unlocked,
    up.is_active,
    up.created_at
FROM public.user_profiles up
WHERE EXISTS (
    SELECT 1 FROM public.user_profiles admin_check
    WHERE admin_check.id = auth.uid() 
    AND admin_check.role = 'admin'
);
$$;

-- Update existing users to be unlocked (for existing data)
UPDATE public.user_profiles 
SET is_unlocked = true 
WHERE role = 'admin';

-- Update existing users with standard role to be locked (pending approval)
UPDATE public.user_profiles 
SET is_unlocked = false 
WHERE role = 'standard';