import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import {FormBuilder, FormControl, FormGroup, Validators} from "@angular/forms";
import {LoginService} from "./login.service";
import {ActivatedRoute} from "@angular/router";
import {AuthService} from "../../../Auth/auth.service";

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {

  public formGroup: FormGroup;
  public loginDetailsNotFound: boolean = false;

  constructor(private fb: FormBuilder, private loginService: LoginService, private route: ActivatedRoute, private auth: AuthService) { }

  ngOnInit(): void {

    this.createFormGroup();
  }

  public loginUser(): void {

    if(this.formGroup.valid){
      const email: string = this.formGroup.get('email')?.value;
      const password: string = this.formGroup.get('password')?.value;
      this.loginService.loginUser(email, password).then(res => {
        this.auth.detailsNotFound$.subscribe(detailsFound => {
          this.loginDetailsNotFound = detailsFound
        })
      });
    }

  }

  private createFormGroup(): void {
    this.formGroup = this.fb.group({
        email: new FormControl(null, Validators.required),
        password: new FormControl(null, Validators.required)
      },
      {updateOn: 'submit'});
  }

  navigateToRegister() {
    this.loginService.navigateToLogin();
  }
}
