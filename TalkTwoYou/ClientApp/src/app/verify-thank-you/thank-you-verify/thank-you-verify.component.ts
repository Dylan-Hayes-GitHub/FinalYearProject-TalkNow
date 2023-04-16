import { Component, OnInit } from '@angular/core';
import {ActivatedRoute, Route, Router} from '@angular/router';
import {AuthService} from "../../Auth/auth.service";
import {ThankYouVerifyService} from "./thank-you-verify.service";

@Component({
  selector: 'app-thank-you-verify',
  templateUrl: './thank-you-verify.component.html',
  styleUrls: ['./thank-you-verify.component.css']
})
export class ThankYouVerifyComponent implements OnInit {
  verificationCode: number;
  id: string;
  constructor(private route: ActivatedRoute, private router: Router, private service: ThankYouVerifyService) { }

  ngOnInit(): void {
    this.route.queryParams.subscribe(params => {
      this.verificationCode = +params['verificationcode'];
      this.id = params['id'];
      console.log(this.verificationCode)
      console.log(this.id)
      this.service.verifyUser(this.id, this.verificationCode);
    })
  }

  login() {
    this.router.navigate(['login']);
  }
}
