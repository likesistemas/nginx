import http from 'k6/http';
import { check } from 'k6';
import { Counter } from 'k6/metrics';

export const requests = new Counter('http_reqs');

export const port = __ENV.PORT != null ? __ENV.PORT : "83"
export const urlbase = __ENV.URL != null ? __ENV.URL : "http://127.0.0.1:" + port + "/";
export const body_is = __ENV.BODY != null ? __ENV.BODY : "php";
export const path = __ENV.PATH != null ? __ENV.PATH : '';

export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500'],
  },
};

export default function () {
  const ok = {
    'status is 200': (r) => r.status === 200,
    'response body': (r) => {
      if(r.body === undefined || r.body === null) {
        return false;
      }

      return r.body.indexOf(body_is) !== -1;
    },
  };

  check(http.get(urlbase + path), ok);
}