require "spec_helper"

describe CommentsHelper do
  describe "#comment_input_field_options" do
    context "generic options" do
      let(:field) { build(:comment_form_field) }

      it "adds the field label to the options" do
        expect( comment_input_field_options(field) ).to include(:label => field.label)
      end

      it "adds the required flag to the options if it is required"
      it "does not add the required flag to the options if it is not required"

      it "adds the class 'public' to the wrapper html option when no classes are present"
      it "adds the class 'public' to the wrapper html option when other classes are already present"
    end

    context "when the field is a text field" do
      describe "and max length is 2000" do
        let(:max_length) { 2000 }
        let(:warn_at) { 250 }
        let(:field) { build(:comment_form_text_field, :max_length => max_length) }
        let(:options) { comment_input_field_options(field) }

        it "adds as: :text to the options" do
          expect( options ).to include(:as => :text)
        end

        it "adds data-max-size 2000 in the wrapper_html options" do
          expect( options[:wrapper_html] ).to include(:'data-max-size' => max_length)
        end

        it "adds data-size-warn-at 200 in the wrapper_html options" do
          expect( options[:wrapper_html] ).to include(:'data-size-warn-at' => warn_at)
        end
      end

      describe "and max length is not 2000" do
        let(:max_length) { 150 }
        let(:warn_at) { 7 }
        let(:field) { build(:comment_form_text_field, :max_length => max_length) }
        let(:options) { comment_input_field_options(field) }

        it "adds as: :string to the options" do
          expect( options ).to include(:as => :string)
        end

        it "adds the field max_length to the size option" do
          expect( options ).to include(:size => 150)
        end

        it "adds the field max_length to the data-max-size in the wrapper html option" do
          expect( options[:wrapper_html] ).to include(:'data-max-size' => max_length)
        end

        it "adds data-size-warn-at 7 to the wrapper html option" do
          expect( options[:wrapper_html] ).to include(:'data-size-warn-at' => warn_at)
        end
      end
    end

    context "when the field is a select field" do
      let(:client) { double(:client) }
      let(:field) { build(:comment_form_select_field, :client => client) }
      let(:options) { comment_input_field_options(field) }

      before(:each) do
        allow(client).to receive(:get_option_elements).and_return(
          [build(:comment_form_state_option)]
        )
      end

      it "adds as: :select to the options" do
        expect( options ).to include(:as => :select)
      end

      it "adds collection: field.option_values to the options" do
        expect( options ).to include(:collection => field.option_values)
      end

      it "adds member_value: :value to the options" do
        expect( options ).to include(:member_value => :value)
      end

      it "adds member_label: :label to the options" do
        expect( options ).to include(:member_label => :label)
      end
    end

    context "when the field is a combo field" do
      let(:client) { double(:client) }
      let(:field) { build(:comment_form_combo_field, :client => client) }
      let(:options) { comment_input_field_options(field) }

      # field options need to be built here so that in effect they are
      # memoized in each test below - otherwise they are regenerated
      # causing dependency expectations to fail
      let(:field_options) { [build(:comment_form_state_option)] }

      before(:each) do
        client.stub(:get_option_elements) { field_options }
      end

      it "adds as: :string to the options" do
        expect( options ).to include(:as => :string)
      end

      it "adds a class of 'combo' to the wrapper html option" do
        expect( options[:wrapper_html] ).to include(:class => 'combo')
      end

      it "adds the field dependent_on to the data-dependent-on in the wrapper html option" do
        expect( options[:wrapper_html] ).to include(:'data-dependent-on' => field.dependent_on)
      end

      it "adds the field dependencies as json to the data-dependencies in the wrapper html option" do
        expect( options[:wrapper_html] ).to include(:'data-dependencies' => field.dependencies.to_json)
      end
    end
  end
end
