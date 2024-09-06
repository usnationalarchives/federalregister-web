module DocumentMarkupHelper
  def document_heading_wrapper(&block)
    <<-HTML
      <div class="document-headings">
        <div class="fr-box fr-box-published-alt no-footer">
          <div class="fr-seal-block fr-seal-block-header with-hover">
            <div class="fr-seal-content">
              <span class="h6">Document Headings</span>
              <div class="fr-seal-meta">
                <div class="fr-seal-desc">
                  <p>
                    Document headings vary by document type but may contain
                    the following:
                  </p>
                  <ol class="bullets">
                    <li>
                      the agency or agencies that issued and signed a document
                    </li>
                    <li>
                      the number of the CFR title and the number of each part
                      the document amends, proposes to amend, or is directly
                      related to
                    </li>
                    <li>
                      the agency docket number / agency internal file number
                    </li>
                    <li>
                      the RIN which identifies each regulatory action listed in
                      the Unified Agenda of Federal Regulatory and Deregulatory
                      Actions
                    </li>
                  </ol>
                  <p>
                    See the
                    <a href="https://www.archives.gov/files/federal-register/write/handbook/ddh.pdf#page=9">
                      Document Drafting Handbook
                    </a>
                    for more details.
                  </p>
                </div>
              </div>
            </div>
          </div>
          <div class="content-block ">
            #{yield}
          </div>
        </div>
      </div>
    HTML
  end
end
