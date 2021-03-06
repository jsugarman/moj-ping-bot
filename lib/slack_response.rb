# frozen_string_literal: true

# Slack response objects:
# constructs an appropriate slack message "attachment"
# based on the response to the ping or healthcheck
# endpoint
#
class SlackResponse
  attr_reader :domain, :response

  def initialize(domain, response)
    @domain = domain
    @response = response.respond_to?(:body) ? response.body : response
  end

  def attachment
    if response
      return error("problems contacting #{domain}!", response) if errored?
      return warning("could be problems on #{domain}!", response) if warned?
      success("#{domain} looks good!", response)
    else
      failure("#{domain} is not well!")
    end
  end

  private

  def errored?
    JSON.parse(response).key?('error')
  end

  def warned?
    r = JSON.parse(response)
    r.values.any? { |el| el.to_s.match?(/\bfalse\b/i) } ||
      r.values.any? { |el| el.to_s.match?(/\b(?:4[0-9]{2}|5[0-4][0-9]|550)\b/) }
  end

  def success(pretext, response)
    success_template(pretext, response)
  end

  def error(pretext, response)
    error_template(pretext, response)
  end

  def warning(pretext, response)
    warning_template(pretext, response)
  end

  def failure(text)
    failure_template(text)
  end

  def success_template(pretext, response)
    {
      fallback: 'Success',
      color: 'good',
      pretext: ":penguin: Woohoo! #{pretext}",
      fields: present(response)
    }
  end

  def warning_template(pretext, response)
    {
      fallback: 'Warning!',
      color: 'warning',
      pretext: ":penguin: Meep! #{pretext}",
      fields: present(response)
    }
  end

  def error_template(pretext, response)
    {
      fallback: 'Error',
      color: 'danger',
      pretext: ":penguin: Meep meep! #{pretext}",
      fields: present(response)
    }
  end

  def failure_template(text)
    {
      fallback: 'Failure',
      color: 'danger',
      pretext: ':penguin: Meep meep!',
      text: text
    }
  end

  def present(response)
    attributes = JSON.parse(response)
    attributes.each_with_object([]) do |(k, v), memo|
      if v.is_a?(Hash)
        memo << present(v.to_json)
        memo.flatten!
      else
        memo << { title: k.humanize, value: v.to_s, short: true }
      end
    end
  end
end
