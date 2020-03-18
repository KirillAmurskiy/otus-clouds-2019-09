output "lb_dns_name" {
  value       = aws_lb.otus-17-lb.dns_name
  description = "The domain name of the load balancer"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.otus-17-cf-distribution.domain_name
  description = "The domain name of the load balancer"
}