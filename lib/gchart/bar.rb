module Gchart
  class Bar < Chart
    def type
      "b" + (horizontal ? "h" : "v") + bar_presentation
    end

    private

    def bar_presentation
      if @overlapped
        'o'
      elsif @grouped
        'g'
      else
        's'
      end
    end
  end
end
