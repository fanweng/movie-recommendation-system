package main

import (
    "os"
    "fmt"
    "html"
    "log"
    "net/http"
    "net/url"
    "io/ioutil"
)

func main() {

    loadBalancerIP := os.Args[1]
    loadBalancerPort := os.Args[2]

    addMovieAPI := func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "API for adding a movie to database is not yet implemented")
    }

    autocompleteAPI := func(w http.ResponseWriter, r *http.Request) {
        queryParams := r.URL.Query()
        searchText := queryParams.Get("q")
        if searchText == "" {
            fmt.Fprintf(w, "request must contain a valid \"q\" parameter and value\n")
            return
        }
        fmt.Printf("parsed search text: %s\n", searchText)

        searchURL := url.URL {
            Scheme:     "http",
            Host:       loadBalancerIP + ":" + loadBalancerPort,
            Path:       "search",
            ForceQuery: true,
            RawQuery:   "q=" + searchText,
        }
        fmt.Printf("sending request url to elastic search: %s\n", searchURL.String())

        res, err := http.Get(searchURL.String())
        if err != nil {
            fmt.Fprintf(w, "error making http request: %s\n", err)
            return
        }

        if (res.StatusCode != 200) {
            fmt.Printf("got response with status code: %d\n", res.StatusCode)
            w.WriteHeader(500)
            fmt.Fprintf(w, "internal error: 500\n")
            return
        }

        resBody, err := ioutil.ReadAll(res.Body)
        if err != nil {
            w.WriteHeader(500)
            fmt.Fprintf(w, "can't read content: %s\n", err)
            return
        }
        fmt.Fprintf(w, "%s", resBody)
    }

    http.HandleFunc("/autocomplete", autocompleteAPI)
    http.HandleFunc("/addMovie", addMovieAPI)


    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello, %q", html.EscapeString(r.URL.Path))
    })

    http.HandleFunc("/google", func(w http.ResponseWriter, r *http.Request){
        requestURL := "http://www.google.com"
        res, err := http.Get(requestURL)
        if err != nil {
            fmt.Fprintf(w, "error making http request: %s\n", err)
            return
        }

        if (res.StatusCode != 200) {
            fmt.Printf("got response with status code: %d\n", res.StatusCode)
            w.WriteHeader(500)
            fmt.Fprintf(w, "internal error: 500\n")
            return
        }

        resBody, err := ioutil.ReadAll(res.Body)
        if err != nil {
            w.WriteHeader(500)
            fmt.Fprintf(w, "can't read content: %s\n", err)
            return
        }
        fmt.Fprintf(w, "%s", resBody)
    })

    log.Fatal(http.ListenAndServe(":80", nil))

}
