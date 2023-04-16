import { HttpClient, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import {BehaviorSubject, map, Observable, Subscription, take} from 'rxjs';
import { Constants } from '../Models/Constants';
import { Jwt, LoginDao } from '../Models/Tokens';
import { UserLogin, UserVerficationDao } from '../Models/User';
import {getAuth, signInWithEmailAndPassword, User} from "@angular/fire/auth";
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { getDatabase, ref, update } from '@angular/fire/database';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  //behaviour subjects
  private _isLoggedIn$ = new BehaviorSubject<boolean>(false);
  private _detailsNotFound = new BehaviorSubject<boolean>(false);

  //observables
  isLoggedIn$ = this._isLoggedIn$.asObservable();
  detailsNotFound$ = this._detailsNotFound.asObservable();
  constructor(private http: HttpClient, private router: Router, private auth: AngularFireAuth) {
    const token = localStorage.getItem('jwt') as string;

    this._isLoggedIn$.next(!!token);
   }

   setAuthenticationState(data: boolean){
    this._isLoggedIn$.next(data);
   }

   async refreshAuthState() {
    const token = localStorage.getItem('jwt');

    if(token){
      //check to see if its valid
      //this.http.post
      const jwt: Jwt = {jwtToken: localStorage.getItem('jwt') as string}

      this.http.post<boolean>(Constants.API_URL + 'user/validUser', jwt).subscribe(res => {
        this._isLoggedIn$.next(res);
      })
    } else {
      this._isLoggedIn$.next(true);
    }

  }

   loginUser(newUserLogin: UserLogin) {
    this.http.post<HttpResponse<LoginDao>>('http://localhost:5074/api/user/login', newUserLogin,
    {observe: 'response'}).subscribe(response => {
    if(response.status === 200 && response.body){
      //const tokens: LoginDao = response.body;
      const tokens = response.body as unknown;
      const tokensFromBody = tokens as LoginDao;
      localStorage.setItem('jwt', tokensFromBody.jwtToken);
      localStorage.setItem('refreshtoken', tokensFromBody.refreshToken);
      localStorage.setItem('name', tokensFromBody.username);

      //sign in with firebase
      const auth = getAuth();

      signInWithEmailAndPassword(auth, newUserLogin.Email, newUserLogin.Password).then(user => {
        this.auth.user.pipe(take(1)).subscribe(user => {

          this.http.get(`${Constants.API_URL }user/GetuserDetails?firebaseId=${user?.uid}`).subscribe(userData  => {
            let jsonData = userData as any;

            localStorage.setItem(Constants.USER_FIRST_NAME, jsonData["FirstName"]);
            localStorage.setItem(Constants.USER_FIRST_NAME, jsonData["LastName"]);
            localStorage.setItem(Constants.USER_FIRST_NAME, jsonData["Email"]);

            var userInfo = {
              "FirstName": jsonData["FirstName"],
              "LastName": jsonData["LastName"],
              "Email": jsonData["Email"]
            };

            const loggedInUserRef = ref(getDatabase(), user?.uid);

            update(loggedInUserRef, userInfo).then(finished => {
              this.router.navigate(['chat'])
            });
          })
          //perform api call to get user data from SQL database

          //store details in firebase


          //await userRef.update(userInfo);
        })
      })

    }
  },
      error => {
        if(error.status === 401){
          localStorage.setItem('loginAttempt', 'yes');
          this.router.navigate(['verify']);
        } else if(error.status === 404){
          //set details found to true
          this._detailsNotFound.next(true);
        }
      })


  }

  resetState(): boolean{
    const token = localStorage.getItem('jwt');
    const sucessfulLoginAttempt = localStorage.getItem('loginAttempt');
    let res: any  = false;

    if(!token && !sucessfulLoginAttempt){
      return res;

    } else {
    const jwt: Jwt = {jwtToken: localStorage.getItem('jwt') as string}
      res = this.http.post<boolean>(Constants.API_URL  + 'user/validUser', jwt);
      if(!res){
        localStorage.removeItem('jwt');
      }
      localStorage.removeItem('loginAttempt');
      return res;
    }
  }

  fullyVerified() {
    return this.auth.user.pipe(
      take(1)
    ).subscribe(firebaseUser => {
      if(firebaseUser != null){
        let verificationDao: UserVerficationDao = new class implements UserVerficationDao {
          FirebaseId: string;
        }
        verificationDao.FirebaseId = firebaseUser.uid;
        this.http.post<boolean>(Constants.API_URL  + 'user/isUserFullyVerified', verificationDao).subscribe(value => {
          if(!value){
            this.router.navigate(['verify']);
          }
        });
      }
    })
  }

}
