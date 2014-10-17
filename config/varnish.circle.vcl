backend my_fr2 {
  .host = "127.0.0.1";
  .port = "3000";
}

backend fr2 {
  .host = "www.federalregister.gov";
  .port = "80";
}

sub vcl_recv {
    # Reject Non-RFC2616 or CONNECT or TRACE requests.
    if (req.request != "GET" &&
      req.request != "HEAD" &&
      req.request != "PUT" &&
      req.request != "POST" &&
      req.request != "OPTIONS" &&
      req.request != "DELETE") {
        return (pipe);
    }

    # Pass my_fr2 requests to my_fr2
    if (req.url ~ "^/clippings" ){
        set req.backend = my_fr2;
        set req.http.host = "my-fr2.local";
    }
    else {
        set req.backend = fr2;
        set req.http.host = "www.federalregister.gov";
        remove req.http.Accept-Encoding;
    }
    
    # either return lookup for caching or return pass for no caching
    
      return (pass);
    
}

sub vcl_fetch {
    
        unset beresp.http.Cache-Control;
        unset beresp.http.Etag;
    
    
    esi;
}
