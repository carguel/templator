module Templator

  module Actions

    def param(varname)
      parameters.get(varname) || parameters.get("#{context}.#{varname}")
    end

  end
end
