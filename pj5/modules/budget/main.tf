resource "aws_sns_topic" "std17_budget_alert" {
    name = "std17-budget-alert"
}

resource "aws_sns_topic_subscription" "std17_budget_email" {
    topic_arn = aws_sns_topic.std17_budget_alert.arn
    protocol  = "email"
    endpoint  = var.alert_email
}

resource "aws_budgets_budget" "std17_monthly" {
    name         = "std17-monthly-budget"
    budget_type  = "COST"
    limit_amount = "245"
    limit_unit   = "USD"
    time_unit    = "MONTHLY"

    notification {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 50
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = [var.alert_email]
    }

    notification {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 80
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = [var.alert_email]
    }

    notification {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 100
        threshold_type             = "PERCENTAGE"
        notification_type          = "FORECASTED"
        subscriber_email_addresses = [var.alert_email]
    }
}