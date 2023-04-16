using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TalkTwoYou.Migrations
{
    /// <inheritdoc />
    public partial class registerStatusChange : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "Verified",
                table: "RegisterStatus",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Verified",
                table: "RegisterStatus");
        }
    }
}
