import { Component, OnInit } from '@angular/core';
import { VerifyUserServiceService } from './verify-user-service.service';
import {AngularFireAuth} from "@angular/fire/compat/auth";
import {take} from "rxjs";
import {Router} from "@angular/router";
import {DataService} from "../../Data/data.service";
import {AuthService} from "../../Auth/auth.service";
import {UserLogin} from "../../Models/User";

@Component({
  selector: 'app-verify-user',
  templateUrl: './verify-user.component.html',
  styleUrls: ['./verify-user.component.css']
})
export class VerifyUserComponent implements OnInit {
  public accountVerified:string = "";
  constructor(private verifyUserService: VerifyUserServiceService, private firebaseAuth: AngularFireAuth, private router: Router, private dataService: DataService, private authService: AuthService) { }

  ngOnInit(): void {
  }

  verifyAccount(): void {

    this.firebaseAuth.user.pipe(
      take(1)
    ).subscribe(loggedInUser => {
      if(loggedInUser != null){
        this.verifyUserService.checkUserVerificationStatus(loggedInUser.uid).subscribe(valid => {
          this.accountVerified = valid ? "verified" : "notverified";
          if(valid){
            this.dataService.$tempUserLogin.pipe(
              take(1)
            ).subscribe(tempUserLogin => {
              this.authService.loginUser(tempUserLogin);
              const blankTempUserLogin: UserLogin = new class implements UserLogin {
                Email = ""
                Password = ""
              }
              this.dataService.setTempUserDetails(blankTempUserLogin);
            })
          }
        });
      }
    })
  }
}
