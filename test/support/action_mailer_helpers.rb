# frozen_string_literal: true

module Support
  module ActionMailerHelpers
    def emails_by_subject(subject)
      ActionMailer::Base.deliveries.select do |mail|
        mail.subject == subject
      end
    end

    def link_with_text(mail, text)
      body = Nokogiri::HTML(mail.body.raw_source)
      link = body.at_xpath("//a[text()=\"#{text}\"]")

      link["href"]
    end
  end
end
