## Schema

User
  id <-> (ObjectId)
  name
  email
  password
  created_at / updated_at
  
Roll
  id (ObjectId)
  owner_id
  name
  max_photos
  photos_count
  created_at / updated_at

UserRolls <--- (Join table)
  id (ObjectId)
  user_id
  roll_id
  status (invited, accepted)
  created_at / updated_at

Photo (select * from photo where roll_id = ...)
  id
  user_id
  roll_id
  photo_url (PFFile, Amazon S3 Url)
  created_at / updated_at
