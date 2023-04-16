import { TestBed } from '@angular/core/testing';
import { HttpClientModule } from '@angular/common/http';
import { RegisterService } from './register.service';
import { FormsModule } from '@angular/forms';
import { AngularFireModule } from '@angular/fire/compat';
import { environment } from 'src/environments/environment';
describe('RegisterService', () => {
  let service: RegisterService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [FormsModule,HttpClientModule, AngularFireModule.initializeApp(environment.firebase)]
        });
    service = TestBed.inject(RegisterService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
