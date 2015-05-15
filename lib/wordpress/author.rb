module Refinery
  module WordPress
    class Author
      attr_reader :author_node

      def initialize(author_node)
        @author_node = author_node
      end

      def login
        author_node.xpath("wp:author_login").text
      end

      def email
        author_node.xpath("wp:author_email").text
      end

      def ==(other)
        login == other.login
      end

      def inspect
        "WordPress::Author: #{login} <#{email}>"
      end

      def to_refinery
        user = Refinery::User.find_by_email email
        if user.nil?
          user = Refinery::User.create username: login, email: email, password: 'password', password_confirmation: 'password'
        end
        user
      end
    end
  end
end
