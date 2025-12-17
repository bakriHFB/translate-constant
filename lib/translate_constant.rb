# frozen_string_literal: true

# rubocop:disable Style/Documentation

require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/enumerable"

# TranslateConstant provides helpers to localize array constants (e.g., REASONS)
# into human-friendly labels via I18n. Include it in your model and call
# `translate_constant :REASONS` to define both class and instance methods for
# accessing translated values.

module TranslateConstant
  extend ActiveSupport::Concern

  module ClassMethods
    # Class-level helpers for defining translated constant methods.
    # Translate an array constant (e.g., REASONS, NEXT_STEPS)
    # Example usage:
    #   translate_constant :REASONS
    #   MyModel.translated_REASONS => { "team_extension" => "Team Extension", ... }
    #   @instance.translated_reason => "Team Extension"

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def translate_constant(const_name, i18n_scope: "activerecord.attributes",
                           i18n_key_template: "%<namespace>s/%<model>s.constant_%<const>s_list.%<value>s")
      const_values = const_get(const_name).map(&:to_s)
      model_key = name.demodulize.underscore
      const_key = const_name.to_s.underscore
      model_namespace = name.deconstantize.underscore

      define_singleton_method("translated_#{const_name}") do |key = nil, locale: nil|
        translations = const_values.index_with do |v|
          i18n_key = "#{i18n_scope}.#{format(i18n_key_template, namespace: model_namespace, model: model_key,
                                                                const: const_key, value: v)}"
          I18n.t(i18n_key, default: v.humanize, locale: locale)
        end
        key ? translations[key.to_s] : translations
      end

      attr_name = const_name.to_s.singularize.downcase
      define_method("translated_#{attr_name}") do
        attr_value = public_send(attr_name)
        attr_value.present? ? self.class.public_send("translated_#{const_name}", attr_value) : nil
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
# rubocop:enable Style/Documentation
