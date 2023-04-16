import {HttpClient, HttpParams} from '@angular/common/http';
import { Injectable } from '@angular/core';
import {NewUser, UserLogin} from '../Models/User';
import {RefreshToken, LoginDao} from "../Models/Tokens";
import {getAuth, createUserWithEmailAndPassword, Auth} from "@angular/fire/auth";
import {Router} from "@angular/router";
import {AngularFireAuth} from "@angular/fire/compat/auth";
import {DataService} from "../Data/data.service";
import {BehaviorSubject, Observable} from "rxjs";

@Injectable({
  providedIn: 'root'
})
export class RegisterService {

  private emailExistsSubject: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);
  private invalidEmailSubject: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);
  private weakPasswordSubject: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);
  constructor(private http: HttpClient, private router: Router, private auth: AngularFireAuth, private dataService: DataService) { }

  public $emailExists: Observable<boolean> = this.emailExistsSubject.asObservable();
  public $invalidEmail: Observable<boolean> = this.invalidEmailSubject.asObservable();
  public $weakPassword: Observable<boolean> = this.weakPasswordSubject.asObservable();
  public registerUser(newUserToRegister: NewUser): void {


    const auth = getAuth();

    //register new user on firebase
    createUserWithEmailAndPassword(auth, newUserToRegister.Email, newUserToRegister.Password)
      .then((userCredential) => {
        // Signed in
        const user = userCredential.user;
        newUserToRegister.FirebaseUid = user.uid;

        //this will do a call to a c# api to store the users details until they have verified themselves via email
        this.http.put('http://localhost:5074/api/user/1',newUserToRegister).subscribe(result => {
        });

        let tempUserDetails: UserLogin = new class implements UserLogin {
          Email = newUserToRegister.Email;
          Password = newUserToRegister.Password;
        }

        this.dataService.setTempUserDetails(tempUserDetails);

        //navigate to home
        this.router.navigate(['verify']);
        // ...
      })
      .catch((error) => {
        const errorCode = error.code;
        const errorMessage = error.message;
        if(errorCode == "auth/email-already-in-use"){
          this.emailExistsSubject.next(true);
        } else if (errorCode == 'auth/invalid-email'){
          this.invalidEmailSubject.next(true);
        } else if(errorCode == 'auth/weak-password'){
          this.weakPasswordSubject.next(true);
        }
        // ..
      });


  }

  public setInvalidEmail(value: boolean) {
    this.invalidEmailSubject.next(value);
  }

  public setEmailExists(value: boolean){
    this.emailExistsSubject.next(value);
  }

  public setWeakPassword(value: boolean){
    this.weakPasswordSubject.next(value);
  }

  public refresh(): void {
    let refreshTok: RefreshToken = new class implements RefreshToken {
      RefreshTokenToValidate: string;
    }

    refreshTok.RefreshTokenToValidate = localStorage.getItem('refreshtoken') as string;
    this.http.post('api/User/refresh', refreshTok).subscribe(res => {
   });

  }

  public navigateToLogin(): void {
    //navigate to home
    this.router.navigate(['login']);
  }
}
