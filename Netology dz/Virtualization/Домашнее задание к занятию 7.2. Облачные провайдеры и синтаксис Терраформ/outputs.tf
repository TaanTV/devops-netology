//id аккаунта
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
//id пользователя
output "user_id" {
  value = data.aws_caller_identity.current.user_id
}
//регион
output "region" {
  value = data.aws_region.current.name
}

//ARN (Amazon Resource Name - уникальный глобальный номер amazon)
output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}
