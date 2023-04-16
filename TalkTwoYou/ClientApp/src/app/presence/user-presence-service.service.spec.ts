import { TestBed } from '@angular/core/testing';
import { AngularFireModule } from '@angular/fire/compat';
import { environment } from 'src/environments/environment';
AngularFireModule

import { UserPresenceServiceService } from './user-presence-service.service';

describe('UserPresenceServiceService', () => {
  let service: UserPresenceServiceService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [AngularFireModule.initializeApp(environment.firebase),
      ],
      providers: [UserPresenceServiceService]
    });
    service = TestBed.inject(UserPresenceServiceService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
