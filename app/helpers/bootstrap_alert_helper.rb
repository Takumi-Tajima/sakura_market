module BootstrapAlertHelper
  def bootstrap_alert_class_for(key)
    case key
    when 'alert'
      'warning'
    when 'notice'
      'success'
    when 'error'
      'danger'
    else
      'info'
    end
  end
end
