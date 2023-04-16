import { HttpClient, HttpErrorResponse, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { RefreshToken, LoginDao } from 'src/app/Models/Tokens';
import {UserLogin} from "../../../Models/User";
import {Router} from "@angular/router";
import {AngularFireAuth} from "@angular/fire/compat/auth";
import {getAuth, signInWithEmailAndPassword, User} from "@angular/fire/auth";
import { AuthService } from 'src/app/Auth/auth.service';

@Injectable({
  providedIn: 'root'
})
export class LoginService {

  constructor(private http: HttpClient, private router: Router, private auth: AuthService) { }

  public async loginUser(email: string, password: string) {

    const newUserLogin: UserLogin =
      {
        Email: email,
        Password: password
      }

      this.auth.loginUser(newUserLogin);
  }

  public navigateToLogin(): void {
    this.router.navigate(['register']);
  }
}
