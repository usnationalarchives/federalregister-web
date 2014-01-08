module Features
  module ClippingHelpers
    def clip_document
      visit '/articles/2014/01/01/4242-4242/test-document'

      within '#clipping-actions' do
        find("#add-to-folder").click
      end
    end
  end
end

