# frozen_string_literal: true

class UserAccountGenerator
  USERNAME_CHARACTERS = %w[
    a b c d e f g h i j k m n p q r s t u v w x y z
    1 2 3 4 5 6 7 8 9
  ]
  PASSWORD_CHARACTERS = %w[
    a b c d e f g h i j k m n p q r s t u v w x y z
    1 2 3 4 5 6 7 8 9
  ]
  SPECIAL_CHARCTERS = %w[
    ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ { | } ~
  ]
  MAX_GENERATION_AMOUNT = 50

  def generate(amount: 10)
    amount
      .clamp(0, MAX_GENERATION_AMOUNT)
      .times
      .map { generate_account }
  end

  def generate_password
    generate_random(PASSWORD_CHARACTERS * 12 + SPECIAL_CHARCTERS, length: 12)
  end

  private

  def generate_account
    username = generate_username
    password = generate_password

    {
      username:,
      email: "#{username}@#{Rails.application.config.generated_account_domain}",
      password:
    }
  end

  def generate_random(characters, length: 12)
    SecureRandom.send(:choose, characters, length)
  end

  def generate_username
    generate_random(USERNAME_CHARACTERS, length: 8)
  end
end
