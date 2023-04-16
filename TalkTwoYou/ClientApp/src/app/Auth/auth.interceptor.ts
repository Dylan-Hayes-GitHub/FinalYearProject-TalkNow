import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HTTP_INTERCEPTORS,
  HttpEventType,
  HttpResponse,
  HttpErrorResponse, HttpClient
} from '@angular/common/http';
import {Constants} from "../Models/Constants";
import {catchError, map, Observable, throwError} from 'rxjs';
import { HomeComponent} from "../home/home.component";
import { LoginService } from '../login/login/login/login.service';
import {RefreshToken, LoginDao} from '../Models/Tokens';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  private home: HomeComponent;
  constructor(private loginService: LoginService, private http: HttpClient) {}

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    let token = localStorage.getItem('jwt');
    let refreshTokenFromStorage = localStorage.getItem('refreshtoken');
    let jwtTokwn = token ? token : '';
    refreshTokenFromStorage = refreshTokenFromStorage ? refreshTokenFromStorage : '';
    const clonedRequest = request.clone({setHeaders: {'Authorization': 'Bearer ' + jwtTokwn}})
    const refreshToken: RefreshToken = { RefreshTokenToValidate: refreshTokenFromStorage}
    return next.handle(clonedRequest).pipe(catchError(errorData => {

        if(errorData.status === 401) {
          this.http.post(Constants.API_URL + 'user/refresh', refreshToken).subscribe(response => {
              const newTokens = response as LoginDao;

              //save to local storage
              localStorage.setItem('jwt', newTokens.jwtToken);
              localStorage.setItem('refreshToken', newTokens.refreshToken);

              let updatedClonedRequest = request.clone({setHeaders: {'Authorization': `Bearer ${jwtTokwn}`}});
              return next.handle(updatedClonedRequest);
          })
          // this.refreshUser(refreshToken).subscribe(res => {

          // });
         // this.loginService.refreshToken(refreshToken);
        } else {

        }

      return throwError(errorData);
    }));

  }

  // private refreshUser(refreshToken: RefreshToken): Observable<any> {
  //
  //   // return this.http.post(`${Constants.API_URL}api/User/refresh`, refreshToken);
  // }
}
