import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { Router } from '@angular/router';
import {Observable, take} from 'rxjs';
import { AuthService } from 'src/app/Auth/auth.service';
import {UserVerficationDao} from "../../Models/User";
import {Constants} from "../../Models/Constants";

@Injectable({
  providedIn: 'root'
})
export class VerifyUserServiceService {

  constructor(private authService: AuthService, private http: HttpClient) { }

  checkUserVerificationStatus(uid: string): Observable<boolean>{

    let verificationDao: UserVerficationDao = new class implements UserVerficationDao {
      FirebaseId: string;
    }

    verificationDao.FirebaseId = uid;

    return this.http.post<boolean>(Constants.API_URL + 'user/isUserFullyVerified', verificationDao);

  }
}
