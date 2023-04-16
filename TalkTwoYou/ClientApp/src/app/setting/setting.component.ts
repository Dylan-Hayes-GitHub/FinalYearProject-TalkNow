import { Component, Input, OnInit } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { CurrentConversationUserDetails, UserUpdatedDetails } from '../Models/User';
import { SettingsService } from './settings.service';

@Component({
  selector: 'app-setting',
  templateUrl: './setting.component.html',
  styleUrls: ['./setting.component.css']
})
export class SettingComponent implements OnInit {
  public formGroup: FormGroup;

  @Input() loggedInUser: CurrentConversationUserDetails;

  constructor(private fb: FormBuilder, private settingsService: SettingsService) { }

  ngOnInit(): void {
    this.createFormGroup();
  }
  createFormGroup() {
    this.formGroup = this.fb.group({
      firstName: new FormControl(this.loggedInUser.FirstName, Validators.required),
      lastName: new FormControl(this.loggedInUser.LastName, Validators.required),
      email: new FormControl(this.loggedInUser.Email, Validators.required),
      oldPassword: new FormControl(null),
      newPassword: new FormControl(null)
    });
  }

  validatePasswordInputs(event: any) {
    let oldPasswordControl = this.formGroup.get('oldPassword');
    let newPasswordControl = this.formGroup.get('newPassword');

    let hasValue = oldPasswordControl?.value;
    if(oldPasswordControl?.pristine == false && oldPasswordControl.value == ""){

        newPasswordControl?.clearValidators();

    }
    else if (oldPasswordControl?.value != null && newPasswordControl?.value == null) {
      newPasswordControl?.setValidators(Validators.required);
    }

    if (newPasswordControl?.value !== hasValue) {
      newPasswordControl?.updateValueAndValidity();
    }
  }

  get newPasswordControl() {
    return this.formGroup.get('newPassword');
  }


  public settingsChange(): void {

    if(this.formGroup.valid){
      //update user settings
      let updatedUserDetails: UserUpdatedDetails = new class implements UserUpdatedDetails {
        FirstName: string;
        LastName: string;
        Email: string;
        OldPassword: string;
        NewPassword: string;
      };

      //get user details from form group
      updatedUserDetails.FirstName = this.formGroup.get('firstName')?.value;
      updatedUserDetails.LastName = this.formGroup.get('lastName')?.value;
      updatedUserDetails.Email = this.formGroup.get('email')?.value;
      if(this.formGroup.get('oldPassword')?.value != null){
        updatedUserDetails.OldPassword = this.formGroup.get('oldPassword')?.value;
        updatedUserDetails.NewPassword = this.formGroup.get('newPassword')?.value;
      } else {
        updatedUserDetails.OldPassword = "";
        updatedUserDetails.NewPassword = "";
      }


      this.settingsService.updateUserDetails(updatedUserDetails);
    }
  }

  uploadUserImage($event: any) {
    if($event.target.files[0]){
      const reader = new FileReader();
      reader.readAsDataURL($event.target.files[0]);
      reader.onload = (async (image) => {
        await this.settingsService.uploadImage($event.target.files[0], this.loggedInUser.FirebaseId).then(r => r);
      })
    }
  }

}
