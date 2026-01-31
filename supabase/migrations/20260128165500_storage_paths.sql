alter table public.assets
  add column if not exists mesh_storage_path text,
  add column if not exists texture_storage_path text,
  add column if not exists pbr_metalness_storage_path text,
  add column if not exists pbr_roughness_storage_path text,
  add column if not exists pbr_normal_storage_path text;
