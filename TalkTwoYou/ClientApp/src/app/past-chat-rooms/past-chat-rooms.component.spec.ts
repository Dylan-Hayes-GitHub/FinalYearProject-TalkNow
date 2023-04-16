import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpClientModule } from '@angular/common/http';
import { PastChatRoomsComponent } from './past-chat-rooms.component';
import { PastChatRoomServiceService } from './past-chat-room-service.service';
import { environment } from 'src/environments/environment';
import { AngularFireModule } from '@angular/fire/compat';
describe('PastChatRoomsComponent', () => {
  let component: PastChatRoomsComponent;
  let fixture: ComponentFixture<PastChatRoomsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [HttpClientModule, AngularFireModule.initializeApp(environment.firebase)],
      declarations: [ PastChatRoomsComponent ],
      providers: [PastChatRoomServiceService]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PastChatRoomsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
