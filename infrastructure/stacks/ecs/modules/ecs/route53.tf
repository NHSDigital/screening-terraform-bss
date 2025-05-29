# resource "aws_route53_record" "sample_app" {
#   zone_id = data.terraform_remote_state.route53.outputs.dns_zone_id
#   name    = "sample-app.${var.envtype1}${var.subenv}.${var.envdomain}.uk"
#   type    = "A"

#   alias {
#     evaluate_target_health = true
#     name                   = aws_alb.application_load_balancer.dns_name
#     zone_id                = aws_alb.application_load_balancer.zone_id
#   }
# }
