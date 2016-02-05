require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Images" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "with embedded images present" do
    before :all do
      @xslt_vars = {
        'image_identifiers' => "EP01MY09.019",
        'image_base_url' => "https://s3.amazonaws.com/#{Rails.env}.graphics.federalregister.gov/:identifier/:style.png"
      }
    end

    it "renders the basic markup for an embedded image" do
      process <<-XML
        <GPH DEEP="640" SPAN="3">
        <GID>EP01MY09.019</GID>
        </GPH>
      XML

      expect(html).to have_tag("p.document-graphic") do
        with_tag 'a.document-graphic-link' do
          with_tag 'img.document-graphic-image'
        end
      end
    end

    it "renders the proper attributes for a link in the embedded image" do
      process <<-XML
        <GPH DEEP="640" SPAN="3">
        <GID>EP01MY09.019</GID>
        </GPH>
      XML

      expect(html).to have_tag 'a', with: {
          class: 'document-graphic-link',
          id: 'g-1',
          href: "https://s3.amazonaws.com/#{Settings.s3_buckets.public_images}/ep01my09.019/original.png"
        }
    end

    it "renders the proper attributes for the img tag in the embedded image" do
      process <<-XML
        <GPH DEEP="640" SPAN="3">
        <GID>EP01MY09.019</GID>
        </GPH>
      XML

      expect(html).to have_tag 'img', with: {
          class: 'document-graphic-image full',
          src: "https://s3.amazonaws.com/#{Settings.s3_buckets.public_images}/ep01my09.019/large.png"
        }
    end

    it "renders the proper data attributes for width when @SPAN=3" do
      process <<-XML
        <GPH DEEP="640" SPAN="3">
        <GID>EP01MY09.019</GID>
        </GPH>
      XML

      expect(html).to have_tag('p.document-graphic') do
        with_tag(
          'a.document-graphic-link',
          with: {
            'data-width' => '3',
            'data-height' => '640'
          }
        ) do
          with_tag 'img.document-graphic-image.full'
        end
      end
    end

    it "renders the proper data attributes for width when @SPAN=1" do
      process <<-XML
        <GPH DEEP="320" SPAN="1">
        <GID>EP01MY09.019</GID>
        </GPH>
      XML

      expect(html).to have_tag('p.document-graphic') do
        with_tag(
          'a.document-graphic-link',
          with: {
            'data-width' => '1',
            'data-height' => '320'
          }
        ) do
          with_tag 'img.document-graphic-image.small'
        end
      end
    end

    context "but with an image missing" do
      it "notifies honeybadger" do
        Honeybadger.stub(:notify)

        process <<-XML
          <GPH DEEP="320" SPAN="1">
          <GID>EP00MY00.000</GID>
          </GPH>
        XML

        expect(Honeybadger).to have_received(:notify)
      end
    end
  end
end
