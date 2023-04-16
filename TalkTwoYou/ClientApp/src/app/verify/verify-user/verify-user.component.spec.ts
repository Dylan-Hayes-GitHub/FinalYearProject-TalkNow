import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpClientModule } from '@angular/common/http';
import { VerifyUserComponent } from './verify-user.component';
import { VerifyUserServiceService } from './verify-user-service.service';
import { environment } from 'src/environments/environment';
import { AngularFireModule } from '@angular/fire/compat';
describe('VerifyUserComponent', () => {
  let component: VerifyUserComponent;
  let fixture: ComponentFixture<VerifyUserComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HttpClientModule, AngularFireModule.initializeApp(environment.firebase)],
      declarations: [ VerifyUserComponent ],
      providers: [VerifyUserServiceService]
    })
    .compileComponents();

    fixture = TestBed.createComponent(VerifyUserComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
