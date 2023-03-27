package main

import (
    "fmt"
    "html"
    "log"
    "net/http"
    "io/ioutil"
)

func main() {

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello, %q", html.EscapeString(r.URL.Path))
    })

    http.HandleFunc("/hi", func(w http.ResponseWriter, r *http.Request){
        fmt.Fprintf(w, "Hi")
    })

    http.HandleFunc("/addMovie", func(w http.ResponseWriter, r *http.Request){
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
