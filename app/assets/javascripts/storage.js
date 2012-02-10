function update_user_clipped_document_count(stored_documents) {
  document_count = stored_documents !== undefined ? Object.keys(stored_documents).length : 0; 
  $('a#document-count').html( document_count + 1 );
}
