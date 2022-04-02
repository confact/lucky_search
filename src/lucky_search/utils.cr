module LuckySearch
  module Utils
    def self.document_name(klass : Class)
      klass.name.split("::").last
    end

    def self.document_name(klass : String)
      klass.split("::").last
    end
  end
end
