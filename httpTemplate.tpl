{{$svrType := .ServiceType}}
{{$svrName := .ServiceName}}

public protocol {{.ServiceType}}ServiceProtocol: TheRouterServiceProtocol {
{{- range .MethodSets}}
	{{- if ne .Comment ""}}
	{{.Comment}}
	{{- end}}
	func {{.Name}}(req :{{.Request}}) async throws -> {{.Reply}}
{{- end}}
}

public final class {{.ServiceType}}Service: NSObject, {{.ServiceType}}ServiceProtocol {
    public static var seriverName: String {
        String(describing: {{.ServiceType}}ServiceProtocol.self)
    }

    private let logger = Logger(label: #file)

    // Optional
    func reset() {
        // Reset all properties to default value
    }

{{- range .MethodSets}}
	public func {{.Name}}(req :{{.Request}}) async throws -> {{.Reply}} {
	    let u = String(format: "\(baseURL){{.Path}}")
	    let f = try HTTPRequest {
            // Setup default params
            $0.url = URL(string: u)
            $0.method = .{{.Method}}
            $0.timeout = 100
            {{- if ne .Method "get" }}
            $0.body = try .data(req.jsonUTF8Data(), contentType: MIMEType.json)
            {{- end }}
            $0.headers = HTTPHeaders(headers: [
                .authBearerToken(baseToken)
            ])
        }
        let res = try await f.fetch()

        if let error = res.error {
            throw error // dispatch any error coming from fetch outside the decode.
        }

        guard let data = res.data else {
            throw HTTPError(.emptyResponse)
        }
        let options = JSONDecodingOptions()
        return try {{.Reply}}(jsonString: data.asString!, options: options)
	}
{{- end}}
}
