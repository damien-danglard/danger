module Danger
  module Helpers
    module MarkdownCommentsParsingHelper
      def parse_tables_from_comment(comment)
        comment.scan(MD_TABLE_REGEX)
      end

      def violations_from_table(table)
        content_table = table.split("|---|---|")[1]
        rows = content_table.split("\n").reject { |row| row.empty? }

        rows.map do |row|
          cells = row.split("|").reject { |cell| cell.empty? }.map(&:strip)
          type = kind_from_emoji(cells[0])
          message = cells[1]
          [type, message]
        end
            .reject { |formated_row| Validation.VALID_TYPES.include? formated_row[0] }
            .map do |formated_row|
          (type, message) = formated_row
          Violation.new(message, true, nil, nil, type: type)
        end
      end

      def parse_comment(comment)
        tables = parse_tables_from_comment(comment)
        violations = tables.map { |table| violations_from_table(table) }.flatten

        violations.group_by { |violation| violation.type }
      end

      def kind_from_emoji(text)
        case text
        when "🚫"
          :error
        when "⚠️"
          :warning
        when "📖"
          :message
        when "✅"
          :resolved
        else
          nil
        end
      end

      private

      MD_TABLE_REGEX = %r{\| \|[^\n]*\|\n\|---\|---\|\n(?:\|[^\n]*\|[^\n]*\|\n)*\n}im
    end
  end
end
