# frozen_string_literal: true

require "i18n"

RSpec.describe TranslateConstant do
  it "has a version number" do
    expect(TranslateConstant::VERSION).to be_a(String)
    expect(TranslateConstant::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it "does something useful" do
    expect(true).to eq(true)
  end

  context "behavior with DummyModel" do
    before do
      dummy_class = Class.new do
        include TranslateConstant

        attr_accessor :reason
      end
      stub_const("DummyModel", dummy_class)
      stub_const("DummyModel::REASONS", %i[team_extension budget_cut other].freeze)
      DummyModel.translate_constant :REASONS
    end

    before do
      I18n.available_locales = %i[en ar]
      I18n.backend = I18n::Backend::Simple.new
      I18n.enforce_available_locales = false
      I18n.locale = :en

      I18n.backend.store_translations(:en, {
                                        activerecord: {
                                          attributes: {
                                            "/dummy_model": {
                                              constant_reasons_list: {
                                                team_extension: "Team Extension",
                                                budget_cut: "Budget Cut"
                                              }
                                            }
                                          }
                                        }
                                      })

      I18n.backend.store_translations(:ar, {
                                        activerecord: {
                                          attributes: {
                                            "/dummy_model": {
                                              constant_reasons_list: {
                                                team_extension: "تمديد الفريق",
                                                budget_cut: "تقليص الميزانية"
                                              }
                                            }
                                          }
                                        }
                                      })
    end

    describe ".translated_REASONS" do
      it "returns a hash of translations with defaults for missing keys" do
        translations = DummyModel.translated_REASONS
        expect(translations).to include("team_extension" => "Team Extension")
        expect(translations).to include("budget_cut" => "Budget Cut")
        expect(translations["other"]).to eq("Other")
      end

      it "returns a single translation when a key is provided" do
        expect(DummyModel.translated_REASONS(:team_extension)).to eq("Team Extension")
        expect(DummyModel.translated_REASONS("budget_cut")).to eq("Budget Cut")
      end

      it "respects the provided locale" do
        expect(DummyModel.translated_REASONS(:team_extension, locale: :ar)).to eq("تمديد الفريق")
        expect(DummyModel.translated_REASONS(:budget_cut, locale: :ar)).to eq("تقليص الميزانية")
      end
    end

    describe "#translated_reason" do
      it "returns nil when attribute is blank" do
        m = DummyModel.new
        expect(m.translated_reason).to be_nil
      end

      it "uses the class translation for the attribute value" do
        m = DummyModel.new
        m.reason = :team_extension
        expect(m.translated_reason).to eq("Team Extension")
      end

      it "uses defaults when translation key is missing" do
        m = DummyModel.new
        m.reason = :other
        expect(m.translated_reason).to eq("Other")
      end
    end

    context "when constant is missing" do
      it "raises NameError" do
        stub_const("TempModel", Class.new do
          include TranslateConstant
        end)
        expect { TempModel.translate_constant(:MISSING) }.to raise_error(NameError)
      end
    end
  end
end
