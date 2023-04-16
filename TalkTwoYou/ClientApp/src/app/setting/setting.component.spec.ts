import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { SettingComponent } from './setting.component';
import { SettingsService } from './settings.service';
import { HttpClientModule } from '@angular/common/http';
import { AngularFireModule } from '@angular/fire/compat';
import { environment } from 'src/environments/environment';
import { CurrentConversationUserDetails } from '../Models/User';
describe('SettingComponent', () => {
  let component: SettingComponent;
  let fixture: ComponentFixture<SettingComponent>;

  let loggedInUser: CurrentConversationUserDetails = new class implements CurrentConversationUserDetails {
    FirstName: string;
    LastName: string;
    deviceNotificationToken: string;
    hasProfilePicture: boolean;
    FirebaseId: string;
    userProfileUrl?: string | undefined;
    Email: string;
  }



  beforeEach(async () => {

    await TestBed.configureTestingModule({
      imports: [ReactiveFormsModule, HttpClientModule, AngularFireModule.initializeApp(environment.firebase)],
      declarations: [ SettingComponent ],
      providers: [SettingsService]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SettingComponent);
    component = fixture.componentInstance;

    loggedInUser.FirstName = 'Dylan';
    loggedInUser.LastName = 'Hayes';
    loggedInUser.Email = 'email';
    loggedInUser.deviceNotificationToken = 'token';
    loggedInUser.hasProfilePicture = false;
    loggedInUser.FirebaseId = 'fireid';
    component.loggedInUser = loggedInUser;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
