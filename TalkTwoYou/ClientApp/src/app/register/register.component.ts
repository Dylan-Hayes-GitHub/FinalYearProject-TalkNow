import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { NewUser } from '../Models/User';
import { RegisterService } from './register.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {

  public formGroup: FormGroup;
  public test: string;

  public emailExistsAlready: boolean = false;
  public invalidEmailFormat: boolean = false;
  public weakPassword: boolean = false;
  constructor(private fb: FormBuilder, private registerService: RegisterService) { }

  ngOnInit(): void {

    localStorage.setItem('test', 'test');
    //create the form group on inital load of component
    this.createFormGroup();
    this.test = localStorage.getItem('jwt') as string;
  }


  public createFormGroup(): void {
    this.formGroup = this.fb.group({
      firstName: new FormControl(null, Validators.required),
      lastName: new FormControl(null, Validators.required),
      email: new FormControl(null, Validators.required),
      password: new FormControl(null, Validators.required)
    },
      {updateOn: 'submit'});
  }

  public registerUser(): void {

    //first ensure that the form is valid
    if(this.formGroup.valid){
      this.registerService.setEmailExists(false);
      this.registerService.setInvalidEmail(false);
      this.registerService.setWeakPassword(false);
      //create a new user object and provide it to service to register new user

      const firstName: string = this.formGroup.get('firstName')?.value;
      const lastName: string = this.formGroup.get('lastName')?.value;
      const email: string = this.formGroup.get('email')?.value;
      const password: string = this.formGroup.get('password')?.value;


    const newUserToRegister: NewUser = {
        FirstName:firstName,
        LastName: lastName,
        Email: email,
        Password: password,
        FirebaseUid: ''
      }

      this.registerService.registerUser(newUserToRegister);
      this.registerService.$emailExists.subscribe(emailExists => {
        this.emailExistsAlready = emailExists;
      })

      this.registerService.$invalidEmail.subscribe(invalidEmailFormat => {
        this.invalidEmailFormat = invalidEmailFormat;
      })

      this.registerService.$weakPassword.subscribe(weakPassword => {
        this.weakPassword = weakPassword;
      })
    }
  }

  refresh() {
    this.registerService.refresh();
  }

  navigateToLogin() {
    this.registerService.navigateToLogin();
  }
}
