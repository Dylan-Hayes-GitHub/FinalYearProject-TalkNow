import { TestBed } from '@angular/core/testing';
import { HttpClientModule } from '@angular/common/http';
import { VerifyUserServiceService } from './verify-user-service.service';
import { environment } from 'src/environments/environment';
import { AngularFireModule } from '@angular/fire/compat';
describe('VerifyUserServiceService', () => {
  let service: VerifyUserServiceService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientModule, AngularFireModule.initializeApp(environment.firebase)]
    });
    service = TestBed.inject(VerifyUserServiceService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
