resource "aws_wafv2_web_acl_association" "example" {
  depends_on = [aws_wafv2_web_acl.WAF_WACL]
  resource_arn = aws_api_gateway_stage.my_api_stage.arn
  web_acl_arn  = aws_wafv2_web_acl.WAF_WACL.arn
}

resource "aws_wafv2_web_acl" "WAF_WACL" {
  name        = "Visitor_API_WAF"
  description = "Example of a Cloudfront rate based statement."
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "LimitRatePerIP"
    priority = 0

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}