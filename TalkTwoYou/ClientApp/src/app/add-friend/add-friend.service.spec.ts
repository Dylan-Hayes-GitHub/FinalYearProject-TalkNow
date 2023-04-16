import { TestBed } from '@angular/core/testing';

import { AddFriendService } from './add-friend.service';
import { environment } from 'src/environments/environment';
import { AngularFireModule } from '@angular/fire/compat';
describe('AddFriendService', () => {
  let service: AddFriendService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [AngularFireModule.initializeApp(environment.firebase)],
      providers: [AddFriendService]
    });
    service = TestBed.inject(AddFriendService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
