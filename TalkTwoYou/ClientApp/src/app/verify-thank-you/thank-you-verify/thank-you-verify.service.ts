import { Injectable } from '@angular/core';
import {Router} from "@angular/router";
import {HttpClient} from "@angular/common/http";
import {Constants} from "../../Models/Constants";

@Injectable({
  providedIn: 'root'
})
export class ThankYouVerifyService {

  constructor(private router: Router, private http: HttpClient) { }

  public verifyUser(guid: string, verificationCode: number): void{
    this.http.get(`${Constants.API_URL}user/verify?id=${guid}&verificationcode=${verificationCode}`).subscribe(value => {

    });
  }
}
