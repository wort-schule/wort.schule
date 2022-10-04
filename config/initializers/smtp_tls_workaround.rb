# cf. https://github.com/mikel/mail/pull/1435

module DisableStarttls
  def build_smtp_session
    super.tap do |smtp|
      unless settings[:enable_starttls_auto]
        if smtp.respond_to?(:disable_starttls)
          smtp.disable_starttls
        end
      end
    end
  end
end

Mail::SMTP.prepend DisableStarttls
