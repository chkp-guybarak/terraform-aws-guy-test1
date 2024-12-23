output "cme-iam-role_arn" {
  value = aws_iam_role.cme-iam-role.arn
}
output "cme-iam-role_name" {
  value = aws_iam_role.cme-iam-role.name
}
output "cme_iam_profile_name" {
  value = aws_iam_instance_profile.iam_instance_profile.name
}
output "cme_iam_profile_arn" {
  value = aws_iam_instance_profile.iam_instance_profile.arn
}