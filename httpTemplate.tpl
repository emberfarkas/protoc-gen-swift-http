{{$svrType := .ServiceType}}
{{$svrName := .ServiceName}}

public protocol {{.ServiceType}}ServiceProtocol: TheRouterServiceProtocol {
{{- range .MethodSets}}
	{{- if ne .Comment ""}}
	{{.Comment}}
	{{- end}}
	func {{.Name}}({{.Request}}) async throws -> {{.Reply}}
{{- end}}
}

public final class {{.ServiceType}}Service: NSObject, {{.ServiceType}}ServiceProtocol {
{{- range .MethodSets}}
	func {{.Name}}(req {{.Request}}) async throws -> {{.Reply}} {
	    let f = HTTPRequest {
            // Setup default params
            $0.url = URL(string: String(format: "{}{}", Global.BaseURL, "{{.Path}}"))
            $0.method = .{{.Method}}
            $0.timeout = 100
        }
        let res = try await f.fetch()

        if let error = res.error {
            throw error // dispatch any error coming from fetch outside the decode.
        }

        guard let data = res.data else {
            throw HTTPError(.emptyResponse)
        }
        let options = JSONDecodingOptions()
        return try Member_V1_GenerateCaptchaHandlerReply(jsonString: data.asString!, options: options)
	}
{{- end}}
}
