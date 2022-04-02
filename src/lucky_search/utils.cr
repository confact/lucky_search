module LuckySearch
  module Utils
    def self.document_name(klass : Class)
      Wordsmith::Inflector.pluralize("#{LuckyEnv.environment}_#{klass.name.gsub("::", "").underscore}")
    end

    def self.document_name(klass : String)
      Wordsmith::Inflector.pluralize("#{LuckyEnv.environment}_#{klass.gsub("::", "").underscore}")
    end
  end
end
